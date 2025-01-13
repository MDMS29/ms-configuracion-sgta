-- FUNCION ALMACENADA PARA OBTENER LOS USUARIOS
CREATE OR REPLACE FUNCTION seguridad.fnc_obtener_usuarios(i_params jsonb) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    data_return jsonb;
    v_estado_activo integer := 1;

    v_id_estado integer := COALESCE((i_params->>'estado')::integer, v_estado_activo);
    v_id_empresa integer := COALESCE((i_params->>'empresa')::integer, 0);

BEGIN
    v_data_return := (
        SELECT jsonb_agg(to_jsonb(q)) FROM (
            SELECT
                stu.id_usuario, CONCAT(stu.nombres, ' ', stu.apellidos) AS nombre, stu.usuario, stu.correo
            FROM seguridad.tbl_usuarios stu
            WHERE stu.id_estado = v_id_estado AND (v_id_empresa = 0 OR stu.id_empresa = v_id_empresa)
            ORDER BY id_usuario DESC
        ) AS q
    );

    RETURN jsonb_build_object(
        'statusCode', 200,
        'error', false,
        'message', 'OK',
        'data', COALESCE(v_data_return, '{}'::jsonb)
    );
END
$$;


-- PROCESO ALMACENADO PARA INSERTAR O ACTUALIZAR USUARIOS
CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_usuario(IN i_usuario jsonb, OUT results jsonb) 
LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_usuario seguridad.tbl_usuarios;
    v_estado_activo integer := 1;

    v_id integer := COALESCE((i_usuario->>'id_usuario'), '0')::integer;
    v_nombres text := (i_usuario->>'nombres')::text;
    v_apellidos text := (i_usuario->>'apellidos')::text;
    v_usuario text := (i_usuario->>'usuario')::text;
    v_correo text := (i_usuario->>'correo')::text;
    v_clave text := (i_usuario->>'clave')::text;
    v_id_estado integer := COALESCE((i_usuario->>'id_estado')::integer, v_estado_activo);
    v_id_empresa integer := COALESCE((i_usuario->>'id_empresa')::integer, 0);
    v_usuario_accion integer := COALESCE((i_usuario->>'usuario_accion')::integer, v_estado_activo);

    v_perfiles jsonb := (i_usuario->'perfiles')::jsonb;
    v_perfil jsonb;

    v_acciones jsonb := (i_usuario->'acciones')::jsonb;
    v_accion jsonb;

    v_id_usuario integer;

    statusCode integer := 200;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_empresas WHERE id_empresa = v_id_empresa AND id_estado = v_estado_activo) THEN
        results := jsonb_build_object('statusCode', 400,'error', true, 'message', 'La empresa seleccionadano existe');
        RETURN;
    END IF;

    BEGIN
        IF EXISTS (SELECT 1 FROM seguridad.tbl_usuarios WHERE id_usuario <> v_id AND LOWER(usuario) = LOWER(v_usuario)) THEN
            results := jsonb_build_object('statusCode', 400,'error', true, 'message', 'Ya existe un registro con este usuario');
            RETURN;
        END IF;

        IF EXISTS (SELECT 1 FROM seguridad.tbl_usuarios WHERE id_usuario <> v_id AND LOWER(correo) = LOWER(v_correo)) THEN
            results := jsonb_build_object('statusCode', 400,'error', true, 'message', 'Ya existe un usuario con este correo electronico');
            RETURN;
        END IF;

        IF EXISTS (SELECT 1 FROM seguridad.tbl_usuarios WHERE id_usuario = v_id) THEN
            UPDATE seguridad.tbl_usuarios
            SET nombres = v_nombres, apellidos = v_apellidos, usuario = v_usuario, correo = v_correo, clave = v_clave,
                id_estado = v_id_estado, id_empresa = v_id_empresa, usuario_actua = v_usuario_accion, fecha_actua = now()
            WHERE id_usuario = v_id
            RETURNING * INTO v_tbl_usuario;
        ELSE
            INSERT INTO seguridad.tbl_usuarios (nombres, apellidos, usuario, correo, clave, cm_clave, id_estado, id_empresa, usuario_crea, fecha_crea)
            VALUES (v_nombres, v_apellidos, v_usuario, v_correo, v_clave, false, v_id_estado, v_id_empresa, v_usuario_accion, now())
            RETURNING * INTO v_tbl_usuario;

            statusCode := 201;
        END IF;

        IF v_tbl_usuario.id_usuario IS NULL THEN
            results := jsonb_build_object('statusCode', 400,'error', true,'message', 'No se pudo crear el usuario');
            RETURN;
        END IF;

        FOR v_perfil IN SELECT * FROM jsonb_array_elements(v_perfiles)
        LOOP
            v_perfil := jsonb_set(v_perfil, '{id_usuario}', to_jsonb(v_tbl_usuario.id_usuario));

            CALL seguridad.prc_insertar_actualizar_perfiles_usuario(v_perfil, v_usuario_accion);
        END LOOP;

        FOR v_accion IN SELECT * FROM jsonb_array_elements(v_acciones)
        LOOP
            v_accion := jsonb_set(v_accion, '{id_usuario}', to_jsonb(v_tbl_usuario.id_usuario));

            CALL seguridad.prc_insertar_actualizar_accion_usuario(v_accion, v_usuario_accion);
        END LOOP;

        results := jsonb_build_object(
            'statusCode', statusCode,
            'error', false,
            'message', 'OK',
            'data', jsonb_build_object(
                'id_usuario', v_tbl_usuario.id_usuario,
                'nombre', CONCAT(v_tbl_usuario.nombres, ' ', v_tbl_usuario.apellidos),
                'usuario', v_tbl_usuario.usuario,
                'correo', v_tbl_usuario.correo
            )
        );

    EXCEPTION
        WHEN OTHERS THEN
            results := jsonb_build_object(
                'statusCode', COALESCE((to_jsonb(SQLERRM)->>'statusCode')::int, 500),
                'error', true,
                'message', SQLERRM
            );
            RAISE NOTICE '%', SQLERRM;
            RETURN;
    END;
END;
$$;




-- FUNCION ALMACENADA PARA BUSCAR UN USUARIO POR ID
CREATE OR REPLACE FUNCTION seguridad.fnc_buscar_usuario_id(i_params jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_estado_activo integer := 1;
    v_data_return jsonb;

    v_id integer := COALESCE((i_params->>'id')::integer, 0);
    v_estado integer := COALESCE((i_params->>'estado')::integer, v_estado_activo);
    v_usuario text := COALESCE((i_params->>'usuario')::text, '');
    v_ver_clave boolean := COALESCE((i_params->>'ver_clave')::boolean, false);
BEGIN
    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_usuarios WHERE (v_id = 0 OR id_usuario = v_id) AND (v_usuario = '' OR usuario = v_usuario) AND id_estado = v_estado) THEN
        RETURN jsonb_build_object(
            'statusCode', 404,
            'error', true,
            'message', 'No se ha encontrado el registro'
        );
    END IF;

    v_data_return := (
        SELECT to_jsonb(q) FROM (
            SELECT 
                stu.id_usuario, stu.usuario, stu.nombres, stu.apellidos, stu.correo, stu.cm_clave,
                CASE WHEN v_ver_clave IS TRUE THEN stu.clave ELSE '' END AS clave,
                (
                    SELECT jsonb_agg(to_jsonb(q2)) FROM (
                        SELECT 
                            stpu.id_perfil_usuario, stpu.id_perfil, stpu.id_estado
                        FROM seguridad.tbl_perfiles_usuarios stpu
                        WHERE stpu.id_usuario = v_id AND stpu.id_estado = v_estado
                    ) AS q2
                ) AS perfiles,
                (
                    SELECT jsonb_agg(to_jsonb(q3)) FROM (
                        SELECT 
                            stau.id_accion_usuario, stau.id_accion_perfil, stau.id_accion_perfil, stau.id_estado
                        FROM seguridad.tbl_acciones_usuarios stau
                        WHERE stau.id_usuario = v_id AND stau.id_estado = v_estado
                    ) AS q3
                ) AS acciones
            FROM seguridad.tbl_usuarios stu 
            WHERE (v_id = 0 OR stu.id_usuario = v_id)
            AND stu.id_estado = v_estado
            AND (v_usuario = '' OR stu.usuario = v_usuario)
        ) AS q
    );

    RETURN jsonb_build_object(
        'statusCode', 200,
        'error', false,
        'message', 'OK',
        'data', COALESCE(v_data_return, '{}'::jsonb)
    );
END
$function$
;





-- PROCESO ALMACENADO PARA INACTIVAR Y ACTIVAR USUARIOS
CREATE OR REPLACE PROCEDURE seguridad.prc_inactivar_activar_usuario(IN i_json_data jsonb,OUT results jsonb) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_usuarios seguridad.tbl_usuarios;

    v_id integer := COALESCE((i_json_data->>'id')::integer, 0);
    v_id_estado integer := COALESCE((i_json_data->>'estado')::integer, 0);
    v_usuario integer := COALESCE((i_json_data->>'usuario_accion')::integer, 0);

    v_estado_activo integer := 1;
BEGIN
    BEGIN
		IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_usuarios WHERE id_usuario = v_id) THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se ha encontrado el usuario'
            );
            RETURN;
        END IF;

        UPDATE seguridad.tbl_usuarios SET
            id_estado = v_id_estado,
            usuario_actua = v_usuario,
            fecha_actua = now()
        WHERE id_usuario = v_id
        RETURNING * INTO v_tbl_usuarios;

        IF v_tbl_usuarios.id_usuario IS NULL THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se pudo actualizar el estado de la empresa'
            );
        ELSE
            results := jsonb_build_object(
                'statusCode', 200,
                'error', false,
                'message', CASE WHEN v_id_estado = v_estado_activo THEN 'Se ha activado el registro' ELSE 'Se ha inactivado el registro' END
            );
        END IF;


    EXCEPTION
        WHEN OTHERS THEN
            results := jsonb_build_object(
                'statusCode', 500,
                'error', true,
                'message', SQLERRM
            );
            RAISE NOTICE '%', SQLERRM;
            RETURN;
    END;
END;
$$;
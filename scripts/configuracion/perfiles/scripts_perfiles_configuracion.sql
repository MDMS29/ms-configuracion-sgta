-- PROCESO ALMACENADO PARA CREAR Y ACTUALIZAR PERFILES
CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_perfil(IN i_json_data jsonb, OUT results jsonb)
LANGUAGE 'plpgsql'
AS $$
DECLARE
    v_tbl_perfiles seguridad.tbl_perfiles;
    v_estado_activo integer := 1;

    v_id integer := COALESCE((i_json_data->>'id_perfil')::integer, 0);
    v_id_empresa integer := (i_json_data->>'id_empresa')::integer;
    v_descripcion text := (i_json_data->>'descripcion')::text;
    v_usuario_accion integer := (i_json_data->>'usuario_accion')::integer;
    
    v_acciones jsonb := (i_json_data->'acciones')::jsonb;
    v_accion jsonb;

    statusCode integer := 200;
BEGIN
    -- VALIDAR QUE LA EMPRESA EXISTA
    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_empresas WHERE id_empresa = v_id_empresa) THEN
        results = jsonb_build_object('statusCode', 400, 'message', 'No se ha encontrado la empresa');
        RETURN;
    END IF;

    -- VALIDAR QUE NO EXISTA UN PERFIL CON LA MISMA DESCRIPCION
    IF EXISTS (SELECT 1 FROM seguridad.tbl_perfiles WHERE id_perfil <> v_id AND id_empresa = v_id_empresa AND LOWER(descripcion) = LOWER(v_descripcion)) THEN
        results = jsonb_build_object('statusCode', 400, 'message', 'Ya existe un perfil con la misma descripción');
        RETURN;
    END IF;


    BEGIN
        IF v_id = 0 THEN
            -- INSERTAR
            INSERT INTO seguridad.tbl_perfiles
            (descripcion, id_estado, usuario_crea, fecha_crea, id_empresa)
            VALUES(v_descripcion, v_estado_activo, v_usuario_accion, now(), v_id_empresa)
            RETURNING * INTO v_tbl_perfiles;

            statusCode := 201;
        ELSE
            -- ACTUALIZAR
            UPDATE seguridad.tbl_perfiles
            SET descripcion=v_descripcion, usuario_actua=v_usuario_accion, fecha_actua=now(), id_empresa=v_id_empresa
            WHERE id_perfil=v_id RETURNING * INTO v_tbl_perfiles;
        END IF;

        IF v_tbl_perfiles.id_perfil IS NULL THEN
            results = jsonb_build_object('statusCode', 400, 'message', 'No se pudo realizar la operación');
            RETURN;
        END IF;

        -- INSERTAR O ACTUALIZAR ACCIONES
        FOR v_accion IN SELECT * FROM jsonb_array_elements(v_acciones)
        LOOP
            CALL seguridad.prc_insertar_actualizar_accion_perfil(v_accion, v_tbl_perfiles.id_perfil, v_usuario_accion);
        END LOOP;

        results = jsonb_build_object('statusCode', statusCode, 'message', 'OK', 'data', to_jsonb(v_tbl_perfiles));

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
END
$$;


-- FUNCION ALMACENADA PARA BUSCAR EL PERFIL POR ID
CREATE OR REPLACE FUNCTION seguridad.fnc_buscar_perfil_id(i_params jsonb) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_estado_activo integer := 1;
    v_data_return jsonb;

    v_id integer := COALESCE((i_params->>'id')::integer, 0);
    v_estado integer := COALESCE((i_params->>'estado')::integer, v_estado_activo);
BEGIN
    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_perfiles WHERE id_perfil = v_id) THEN
        RETURN jsonb_build_object(
            'statusCode', 404,
            'error', true,
            'message', 'No se ha encontrado el registro'
        );
    END IF;

    v_data_return := (
        SELECT to_jsonb(q) FROM (
            SELECT 
                stp.id_perfil, stp.descripcion, stp.id_empresa,
                (SELECT COALESCE(jsonb_agg(to_jsonb(q2)), '[]'::jsonb) FROM (
                    SELECT
                        tam.id_accion_perfil, tam.id_accion_menu, tam.id_estado
                    FROM seguridad.tbl_acciones_perfiles tam
                    WHERE tam.id_perfil = stp.id_perfil
                    AND tam.id_estado = v_estado_activo
                ) AS q2) AS acciones
            FROM seguridad.tbl_perfiles stp
            WHERE stp.id_perfil = v_id
            AND stp.id_estado = v_estado
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

-- PROCESO ALMACENADO PARA INACTIVAR Y ACTIVAR UN PERFIL
CREATE OR REPLACE PROCEDURE seguridad.prc_inactivar_activar_perfil(IN i_json_data jsonb,OUT results jsonb) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_perfiles seguridad.tbl_perfiles;

    v_id integer := COALESCE((i_json_data->>'id')::integer, 0);
    v_id_estado integer := COALESCE((i_json_data->>'estado')::integer, 0);
    v_usuario integer := COALESCE((i_json_data->>'usuario_accion')::integer, 0);

    v_estado_activo integer := 1;
BEGIN
    BEGIN
		IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_perfiles WHERE id_perfil = v_id) THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se ha encontrado el perfil'
            );
            RETURN;
        END IF;

        UPDATE seguridad.tbl_perfiles SET
            id_estado = v_id_estado,
            usuario_actua = v_usuario,
            fecha_actua = now()
        WHERE id_perfil = v_id
        RETURNING * INTO v_tbl_perfiles;

        IF v_tbl_perfiles.id_perfil IS NULL THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se pudo actualizar el perfil'
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
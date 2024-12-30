-- FUNCION ALMACENADA PARA OBTENER LAS EMPRESAS
CREATE OR REPLACE FUNCTION seguridad.fnc_obtener_empresas(i_estado integer) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    data_return jsonb;
BEGIN
    data_return := (
        SELECT jsonb_agg(to_jsonb(q)) FROM (
            SELECT
                ste.id_empresa, ste.nit, ste.razon_social, ste.correo, ste.telefono, ste.direccion
            FROM seguridad.tbl_empresas ste
            WHERE ste.id_estado = i_estado
            ORDER BY ste.id_empresa DESC
        ) AS q
    );

    RETURN jsonb_build_object(
        'statusCode', 200,
        'error', false,
        'message', 'OK',
        'data', COALESCE(data_return, '[]'::jsonb)
    );
END 
$$;



-- PROCESO ALMACENADO PARA INSERTAR Y ACTUALIZAR LAS EMPRESAS
CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_empresa(IN i_json_data jsonb, OUT results jsonb) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_empresa seguridad.tbl_empresas;
    v_estado_activo integer := 1;

    v_id integer := COALESCE((i_json_data->>'id_empresa'), '0')::integer;
    v_nit text := (i_json_data->>'nit')::text;
    v_razon_social text := (i_json_data->>'razon_social')::text;
    v_correo text := (i_json_data->>'correo')::text;
    v_telefono text := (i_json_data->>'telefono')::text;
    v_direccion text := (i_json_data->>'direccion')::text;
    v_id_pais int := (i_json_data->>'id_pais')::int;
    v_modulos jsonb := (i_json_data->'modulos')::jsonb;
	v_usuario_accion int := (i_json_data->'usuario_accion')::int;

    v_modulo jsonb;

	statusCode int := 200;
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM seguridad.tbl_empresas WHERE id_empresa <> v_id AND LOWER(nit) = LOWER(v_nit)) THEN
            RAISE EXCEPTION '{"statusCode":400, "message": "Ya existe una empresa con este NIT"}';
        END IF;

		IF EXISTS (SELECT 1 FROM seguridad.tbl_empresas WHERE id_empresa <> v_id AND LOWER(razon_social) = LOWER(v_razon_social) AND id_pais = v_id_pais) THEN
            RAISE EXCEPTION '{"statusCode":400, "message": "Ya existe una empresa con esta razón social"}';
        END IF;

		IF EXISTS (SELECT 1 FROM seguridad.tbl_empresas WHERE id_empresa <> v_id AND LOWER(correo) = LOWER(v_correo)) THEN
            RAISE EXCEPTION '{"statusCode":400, "message": "Ya existe una empresa con este correo electronico"}';
        END IF;

        IF EXISTS (SELECT 1 FROM seguridad.tbl_empresas WHERE id_empresa = v_id) THEN
            UPDATE seguridad.tbl_empresas
            SET nit = v_nit, razon_social = v_razon_social, correo = v_correo, telefono = v_telefono,
                direccion = v_direccion, usuario_actua = v_usuario_accion, fecha_actua = now(), id_pais = v_id_pais
            WHERE id_empresa = v_id
            RETURNING * INTO v_tbl_empresa;
        ELSE
            INSERT INTO seguridad.tbl_empresas (nit, razon_social, correo, telefono, direccion, id_estado, usuario_crea, fecha_crea, id_pais)
            VALUES (v_nit, v_razon_social, v_correo, v_telefono, v_direccion, v_estado_activo, v_usuario_accion, now(), v_id_pais)
            RETURNING * INTO v_tbl_empresa;

			statusCode := 201;
        END IF;

        -- INSERTAR LOS MODULOS PERMITIDOS PARA LA EMPRESA
        FOR v_modulo IN SELECT * FROM jsonb_array_elements(v_modulos)
        LOOP
            CALL seguridad.prc_insertar_actualizar_modulo_empresa(v_modulo, v_tbl_empresa.id_empresa, v_usuario_accion);
        END LOOP;

		results := jsonb_build_object(
            'statusCode', statusCode,
			'error', false,
			'message', 'OK',
            'data', to_jsonb(v_tbl_empresa)
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



-- FUNCION ALMACENADA PARA BUSCAR UNA EMPRESA POR ID
CREATE OR REPLACE FUNCTION seguridad.fnc_buscar_empresa_id(i_params jsonb) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_estado_activo integer := 1;
    v_data_return jsonb;

    v_id integer := (i_params->>'id')::integer;
    v_estado integer := COALESCE((i_params->>'estado')::integer, v_estado_activo);
BEGIN
   IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_empresas WHERE id_empresa = v_id AND id_estado = v_estado) THEN
		RETURN jsonb_build_object(
            'statusCode', 404,
            'error', true,
            'message', 'No se ha encontrado el registro'
        );
    END IF;

    v_data_return := (
        SELECT to_jsonb(q) FROM (
            SELECT
                ste.id_empresa, ste.nit, ste.razon_social, ste.correo, ste.telefono, ste.direccion, ste.id_pais,
                (SELECT COALESCE(jsonb_agg(to_jsonb(q2)), '[]'::jsonb) FROM (
                    SELECT
                        sem.id_modulo, sem.id_modulo_empresa, sem.id_estado
                    FROM seguridad.tbl_modulos_empresas sem
                    WHERE sem.id_empresa = ste.id_empresa
                    AND sem.id_estado = v_estado
                ) AS q2) AS modulos
            FROM seguridad.tbl_empresas ste
            WHERE ste.id_empresa = v_id
            AND ste.id_estado = v_estado
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



-- PROCESO ALMACENADO PARA INACTIVAR Y ACTIVAR LAS EMPRESAS
CREATE OR REPLACE PROCEDURE seguridad.prc_inactivar_activar_empresa(IN i_json_data jsonb,OUT results jsonb) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_empresas seguridad.tbl_empresas;

    v_id integer := COALESCE((i_json_data->>'id'), '0')::integer;
    v_estado integer := COALESCE((i_json_data->>'estado'), '0')::integer;
    v_usuario integer := COALESCE((i_json_data->>'usuario_accion'), '0')::integer;

    v_estado_activo integer := 1;
BEGIN
    BEGIN
		IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_empresas WHERE id_empresa = v_id) THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se encontró la empresa'
            );
            RETURN;
        END IF;

        UPDATE seguridad.tbl_empresas SET
            id_estado = v_estado,
            usuario_actua = v_usuario,
            fecha_actua = now()
        WHERE id_empresa = v_id
        RETURNING * INTO v_tbl_empresas;

        IF v_tbl_empresas.id_empresa IS NULL THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se pudo actualizar el estado de la empresa'
            );
        ELSE
            results := jsonb_build_object(
                'statusCode', 200,
                'error', false,
                'message', CASE WHEN v_estado = v_estado_activo THEN 'Se ha activado el registro' ELSE 'Se ha inactivado el registro' END
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
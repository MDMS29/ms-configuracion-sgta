-- PROCESO ALMACENADO PARA INSERTAR Y ACTUALIZAR LAS ACCIONES

CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_accion(IN i_json_data jsonb,OUT results jsonb) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_accion seguridad.tbl_acciones;

    v_accion_id integer := COALESCE((i_json_data->>'id_accion'), '0')::integer;
    v_descripcion text := (i_json_data->>'descripcion')::text;
    v_usuario integer := (i_json_data->>'usuario_accion')::integer;

    statusCode integer := 200;
BEGIN

	IF EXISTS (SELECT 1 FROM seguridad.tbl_acciones WHERE LOWER(descripcion) = LOWER(v_descripcion) AND (v_accion_id = 0 OR id_accion <> v_accion_id)) THEN
        results := jsonb_build_object(
            'statusCode', 400,
            'error', true,
            'message', 'Ya existe una acción con ese nombre'
        );
        RETURN;
    END IF;

    BEGIN
        IF v_accion_id = 0 THEN
            INSERT INTO seguridad.tbl_acciones (descripcion, id_estado, usuario_crea, fecha_crea)
            VALUES (
                v_descripcion, 1, v_usuario, now()
            )
            RETURNING * INTO v_tbl_accion;

            statusCode := 201;
        ELSE
            UPDATE seguridad.tbl_acciones
            SET descripcion = v_descripcion,
                usuario_actua = v_usuario,
                fecha_actua = now()
            WHERE id_accion = v_accion_id
            RETURNING * INTO v_tbl_accion;
        END IF;

        IF v_tbl_accion.id_accion IS NULL THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se pudo realizar la operación'
            );
        ELSE
            results := jsonb_build_object(
                'statusCode', statusCode,
                'error', false,
                'message', 'OK',
                'data', to_jsonb(v_tbl_accion)
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

-- PROCESO ALMACENADO PARA INACTIVAR Y ACTIVAR LAS ACCIONES

CREATE OR REPLACE PROCEDURE seguridad.prc_inactivar_activar_accion(IN i_json_data jsonb,OUT results jsonb) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_accion seguridad.tbl_acciones;

    v_id integer := COALESCE((i_json_data->>'id'), '0')::integer;
    v_estado integer := COALESCE((i_json_data->>'estado'), '0')::integer;
    v_usuario integer := COALESCE((i_json_data->>'usuario_accion'), '0')::integer;

    v_estado_activo integer := 1;
BEGIN
    BEGIN
		IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_acciones WHERE id_accion = v_id) THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se encontró la acción'
            );
            RETURN;
        END IF;

        UPDATE seguridad.tbl_acciones SET
            id_estado = v_estado,
            usuario_actua = v_usuario,
            fecha_actua = now()
        WHERE id_accion = v_id
        RETURNING * INTO v_tbl_accion;

        IF v_tbl_accion.id_accion IS NULL THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se pudo actualizar la acción'
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
CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_accion(IN i_json_data jsonb,OUT results jsonb) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_accion seguridad.tbl_acciones;

    v_accion_id integer := COALESCE((i_json_data->>'id_accion'), '0')::integer;
    v_descripcion text := (i_json_data->>'descripcion')::text;
    v_usuario integer := (i_json_data->>'usuario_accion')::integer;
BEGIN

	IF EXISTS (SELECT 1 FROM seguridad.tbl_acciones WHERE LOWER(descripcion) = LOWER(v_descripcion) AND (v_accion_id = 0 OR id_accion <> v_accion_id)) THEN
        results := jsonb_build_object(
            'statusCode', 400,
            'error', true,
            'message', 'Ya existe una accion con ese nombre'
        );
        RETURN;
    END IF;

    BEGIN
        INSERT INTO seguridad.tbl_acciones (descripcion, id_estado, usuario_crea, fecha_crea)
        VALUES (
            v_descripcion, 1, v_usuario, now()
        )
        ON CONFLICT (id_accion) DO UPDATE SET
            descripcion = EXCLUDED.descripcion,
            usuario_actua = v_usuario,
            fecha_actua = now()
        RETURNING * INTO v_tbl_accion;

        IF v_tbl_accion.id_accion IS NULL THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se pudo insertar la accion'
            );
        ELSE
            results := jsonb_build_object(
                'statusCode', 200,
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
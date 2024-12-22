-- FUNCION ALMACENADA PARA OBTENER LOS MODULOS

CREATE OR REPLACE FUNCTION seguridad.fnc_obtener_modulos(i_estado integer) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    data_return jsonb;
BEGIN
    data_return := (
        SELECT jsonb_agg(to_jsonb(q)) FROM (
            SELECT
                id_modulo, descripcion,
                CASE WHEN es_menu THEN 'Si' ELSE 'No' END AS es_menu,
                CASE WHEN es_menu THEN link ELSE '-' END AS link
            FROM seguridad.tbl_modulos
            WHERE id_estado = i_estado
            ORDER BY id_modulo
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

-- PROCESO ALMACENADO PARA INSERTAR Y ACTUALIZAR LAS MODULOS

CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_modulo(IN i_json_data jsonb,OUT results jsonb) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_modulo seguridad.tbl_modulos;
    v_estado_activo integer := 1;

    v_id integer := COALESCE((i_json_data->>'id_modulo'), '0')::integer;
    v_descripcion text := (i_json_data->>'descripcion')::text;
    v_es_menu boolean := (i_json_data->>'es_menu')::boolean;
    v_link text := (i_json_data->>'link')::text;
    v_usuario integer := (i_json_data->>'usuario_accion')::integer;

    v_menus jsonb := (i_json_data->>'menus')::jsonb;
    v_menu jsonb;

    statusCode integer := 200;
BEGIN

	IF EXISTS (SELECT 1 FROM seguridad.tbl_modulos WHERE LOWER(descripcion) = LOWER(v_descripcion) AND (v_id = 0 OR id_modulo <> v_id)) THEN
        results := jsonb_build_object(
            'statusCode', 400,
            'error', true,
            'message', 'Ya existe una modulo con este nombre'
        );
        RETURN;
    END IF;

    BEGIN
        IF v_id = 0 THEN
            INSERT INTO seguridad.tbl_modulos (descripcion, es_menu, link, id_estado, usuario_crea, fecha_crea)
            VALUES (
                v_descripcion, v_es_menu, v_link, v_estado_activo , v_usuario, now()
            )
            RETURNING * INTO v_tbl_modulo;

            statusCode := 201;
        ELSE
            UPDATE seguridad.tbl_modulos
            SET descripcion = v_descripcion,
                es_menu = v_es_menu,
                link = v_link,
                usuario_actua = v_usuario,
                fecha_actua = now()
            WHERE id_modulo = v_id
            RETURNING * INTO v_tbl_modulo;
        END IF;



        IF v_tbl_modulo.id_modulo IS NULL THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se pudo realizar la operación'
            );
        ELSE
            IF v_es_menu = false THEN
                FOR v_menu IN SELECT * FROM jsonb_array_elements(v_menus)
                LOOP
                    CALL seguridad.prc_insertar_actualizar_menu(v_tbl_modulo.id_modulo, v_menu, v_usuario);
                END LOOP;
            END IF;

            results := jsonb_build_object(
                'statusCode', statusCode,
                'error', false,
                'message', 'OK',
                'data', to_jsonb(v_tbl_modulo)
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


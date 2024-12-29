-- PROCESO ALMACENADO PARA INSERTAR Y ACTUALIZAR LOS MENUS

CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_menu(modulo_id integer, i_json_data jsonb, usuario_accion integer) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_menu seguridad.tbl_menus;
    v_estado_activo integer := 1;

    v_id integer := COALESCE((i_json_data->>'id_menu'), '0')::integer;
    v_descripcion text := (i_json_data->>'descripcion')::text;
    v_link text := (i_json_data->>'link')::text;
    v_usuario integer := usuario_accion;
    v_estado integer := (i_json_data->>'id_estado')::integer;

    v_acciones jsonb := (i_json_data->'acciones')::jsonb;

    v_accion jsonb;
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM seguridad.tbl_menus WHERE id_menu <> v_id AND LOWER(link) = LOWER(v_link)) THEN
            RAISE EXCEPTION '{"statusCode":400, "message": "Ya existe un menú con el nombre %"}', v_descripcion;
        END IF;

        IF EXISTS (SELECT 1 FROM seguridad.tbl_menus WHERE id_menu = v_id) THEN
            UPDATE seguridad.tbl_menus
            SET descripcion = v_descripcion,
                link = v_link,
                id_estado = v_estado,
                usuario_actua = v_usuario,
                fecha_actua = now()
            WHERE id_menu = v_id
            RETURNING * INTO v_tbl_menu;
        ELSE
            INSERT INTO seguridad.tbl_menus (descripcion, link, id_estado, usuario_crea, fecha_crea, id_modulo)
            VALUES (
                v_descripcion, v_link, v_estado_activo, v_usuario, now(), modulo_id
            )
            RETURNING * INTO v_tbl_menu;
        END IF;

        -- INSERTAR LAS ACCIONES DEL MENU
        FOR v_accion IN SELECT * FROM jsonb_array_elements(v_acciones)
        LOOP
            CALL seguridad.prc_insertar_actualizar_accion_modulo_menu(v_accion, null, v_tbl_menu.id_menu, v_usuario);
        END LOOP;
    END;
END;
$$;


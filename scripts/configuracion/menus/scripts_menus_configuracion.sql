-- PROCESO ALMACENADO PARA INSERTAR Y ACTUALIZAR LAS MODULOS

CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_menu(modulo_id integer, i_json_data jsonb, usuario_accion integer) 
LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_menu seguridad.tbl_menus;
    v_estado_activo integer := 1;

    v_id integer := COALESCE((i_json_data->>'id_menu'), '0')::integer;
    v_descripcion text := (i_json_data->>'descripcion')::text;
    v_link text := (i_json_data->>'link')::text;
    v_usuario integer := usuario_accion;
    v_estado integer := (i_json_data->>'id_estado')::integer;
BEGIN
    BEGIN
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
    END;
END;
$$;


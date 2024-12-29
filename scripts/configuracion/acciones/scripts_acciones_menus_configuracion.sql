--{
 --"id_accion": 1,
 --"id_menu": 2,
 --"id_modulo": 2,
 --"id_estado": 1
--}

CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_accion_modulo_menu(i_json_data jsonb, i_modulo_id integer, i_menu_id integer, i_usuario_accion integer) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_accion_menu seguridad.tbl_acciones_menus;

	v_id_accion_menu int := COALESCE((i_json_data->>'id_accion_menu')::int, '0'::int);
    v_id_accion int := (i_json_data->>'id_accion')::int;
    v_id_modulo int := COALESCE((i_json_data->>'id_modulo')::int, i_modulo_id);
    v_id_menu int := COALESCE((i_json_data->>'id_menu')::int, i_menu_id);
    v_id_estado int := (i_json_data->>'id_estado')::int;

    v_estado_activo int := 1;

    v_nombre_accion jsonb := (SELECT to_jsonb(q) FROM (SELECT descripcion, id_estado FROM seguridad.tbl_acciones WHERE id_accion = v_id_accion) AS q);

	v_accion_menu int := (SELECT id_accion_menu FROM seguridad.tbl_acciones_menus WHERE id_accion_menu = v_id_accion_menu OR (id_modulo = v_id_modulo OR id_menu = v_id_menu ) AND id_accion = v_id_accion);
BEGIN

    IF ((v_nombre_accion->>'id_estado')::int != v_estado_activo) THEN
        RAISE EXCEPTION '{"statusCode":500, "message": "La acción % esta inactiva"}', (v_nombre_accion->>'descripcion')::text;
	END IF;

	IF v_accion_menu IS NOT NULL THEN
        -- ACTUALIZAR
        UPDATE seguridad.tbl_acciones_menus
        SET id_estado=v_id_estado, usuario_actua=i_usuario_accion, fecha_actua=now(), id_menu=COALESCE(v_id_menu, null), id_modulo=COALESCE(v_id_modulo, null), id_accion=v_id_accion
        WHERE id_accion_menu=v_accion_menu
        RETURNING * INTO v_tbl_accion_menu;

        IF v_tbl_accion_menu.id_accion_menu IS NULL THEN
            RAISE EXCEPTION '{"statusCode":500, "message": "No se ha podido actualizar la acción %"}', (v_nombre_accion->>'descripcion')::text;
        END IF;
    ELSE
        -- INSERTAR
        INSERT INTO seguridad.tbl_acciones_menus
        (id_estado, usuario_crea, fecha_crea, id_menu, id_modulo, id_accion)
        VALUES(v_estado_activo, i_usuario_accion, now(), COALESCE(v_id_menu, null), COALESCE(v_id_modulo, null), v_id_accion) RETURNING * INTO v_tbl_accion_menu;

        IF v_tbl_accion_menu.id_accion_menu  IS NULL THEN
            RAISE EXCEPTION '{"statusCode":500, "message": "No se ha podido insertar la acción %"}', (v_nombre_accion->>'descripcion')::text;
        END IF;
    END IF;
END
$$
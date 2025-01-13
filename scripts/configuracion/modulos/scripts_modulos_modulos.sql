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

    v_acciones jsonb := (i_json_data->'acciones')::jsonb;
    v_accion jsonb;

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
            ELSE
                -- INSERTAR LAS ACCIONES DEL MODULO
                FOR v_accion IN SELECT * FROM jsonb_array_elements(v_acciones)
                LOOP
                    CALL seguridad.prc_insertar_actualizar_accion_modulo_menu(v_accion, v_tbl_modulo.id_modulo, null, v_usuario);
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
                'statusCode', COALESCE((to_jsonb(SQLERRM)->>'statusCode')::int, 500),
                'error', true,
                'message', SQLERRM
            );
            RAISE NOTICE '%', SQLERRM;
            RETURN;
    END;
END;
$$;

-- FUNCION ALMACENADA PARA BUSCAR UN MODULO POR ID

CREATE OR REPLACE FUNCTION seguridad.fnc_buscar_modulo_id(i_params jsonb) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_estado_activo integer := 1;
    v_data_return jsonb;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_modulos WHERE id_modulo = (i_params->>'id')::integer) THEN
        RETURN jsonb_build_object(
            'statusCode', 404,
            'error', true,
            'message', 'No se ha encontrado el registro'
        );
    END IF;

    v_data_return := (
        SELECT to_jsonb(q) FROM (
            SELECT
                stm.id_modulo, stm.descripcion, stm.es_menu, stm.link,
                (SELECT COALESCE(jsonb_agg(to_jsonb(q2)), '[]'::jsonb) FROM (
                    SELECT
                        tm.id_menu, tm.descripcion, tm.link,
                        (SELECT COALESCE(jsonb_agg(to_jsonb(q3)), '[]'::jsonb) FROM (
                            SELECT
                                tam.id_accion_menu, tam.id_accion, tam.id_estado
                            FROM seguridad.tbl_acciones_menus tam
                            WHERE tam.id_menu = tm.id_menu
                            AND tam.id_estado = v_estado_activo
                        ) AS q3) AS acciones
                    FROM seguridad.tbl_menus tm
                    WHERE tm.id_modulo = stm.id_modulo
                    AND tm.id_estado = v_estado_activo
                ) AS q2) AS menus,
                (SELECT COALESCE(jsonb_agg(to_jsonb(q4)), '[]'::jsonb) FROM (
                    SELECT
                        tam.id_accion_menu, tam.id_accion, tam.id_estado
                    FROM seguridad.tbl_acciones_menus tam
                    WHERE tam.id_modulo = stm.id_modulo
                    AND tam.id_estado = v_estado_activo
                ) AS q4) AS acciones
            FROM seguridad.tbl_modulos stm
            WHERE stm.id_modulo = (i_params->>'id')::integer
            AND stm.id_estado = (i_params->>'estado')::integer
            ORDER BY stm.id_modulo
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

-- PROCESO ALMACENADO PARA INACTIVAR Y ACTIVAR LAS MODULOS

CREATE OR REPLACE PROCEDURE seguridad.prc_inactivar_activar_modulo(IN i_json_data jsonb,OUT results jsonb) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_modulos seguridad.tbl_modulos;

    v_id integer := COALESCE((i_json_data->>'id'), '0')::integer;
    v_estado integer := COALESCE((i_json_data->>'estado'), '0')::integer;
    v_usuario integer := COALESCE((i_json_data->>'usuario_accion'), '0')::integer;

    v_estado_activo integer := 1;
BEGIN
    BEGIN
		IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_modulos WHERE id_modulo = v_id) THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se encontró el módulo'
            );
            RETURN;
        END IF;

        UPDATE seguridad.tbl_modulos SET
            id_estado = v_estado,
            usuario_actua = v_usuario,
            fecha_actua = now()
        WHERE id_modulo = v_id
        RETURNING * INTO v_tbl_modulos;

        IF v_tbl_modulos.id_modulo IS NULL THEN
            results := jsonb_build_object(
                'statusCode', 400,
                'error', true,
                'message', 'No se pudo actualizar el módulo'
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

-- FUNCION ALMACENADA PARA OBTENER LOS MODULOS CON SUS MENUS Y ACCIONES

CREATE OR REPLACE FUNCTION seguridad.fnc_obtener_modulos_menus_acciones() RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    data_return jsonb;
    v_estado_activo integer := 1;
BEGIN
    data_return := (
        SELECT jsonb_agg(to_jsonb(q)) FROM (
            SELECT
                stm.id_modulo, stm.descripcion, stm.es_menu, stm.link,
                CASE WHEN es_menu THEN 
                    (
                        SELECT jsonb_agg(to_jsonb(q2)) FROM (
                            SELECT
                                tam.id_accion_menu, tam.id_accion, tam.id_estado, sta.descripcion
                            FROM seguridad.tbl_acciones_menus tam
                            INNER JOIN seguridad.tbl_acciones sta ON sta.id_accion = tam.id_accion
                            WHERE tam.id_modulo = stm.id_modulo
                            AND tam.id_estado = v_estado_activo
                        ) AS q2
                    )
                END AS acciones,
                CASE WHEN es_menu IS FALSE THEN
                    (
                        SELECT jsonb_agg(to_jsonb(q3)) FROM (
                            SELECT
                                tm.id_menu, tm.descripcion, tm.link,
                                (SELECT jsonb_agg(to_jsonb(q4)) FROM (
                                    SELECT
                                        tam.id_accion_menu, tam.id_accion, tam.id_estado, sta.descripcion
                                    FROM seguridad.tbl_acciones_menus tam
									INNER JOIN seguridad.tbl_acciones sta ON sta.id_accion = tam.id_accion
                                    WHERE tam.id_menu = tm.id_menu
                                    AND tam.id_estado = v_estado_activo
                                ) AS q4) AS acciones
                            FROM seguridad.tbl_menus tm
                            WHERE tm.id_modulo = stm.id_modulo
                            AND tm.id_estado = v_estado_activo
                        ) AS q3
                    )
                END AS menus
            FROM seguridad.tbl_modulos stm
            WHERE stm.id_estado = v_estado_activo
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


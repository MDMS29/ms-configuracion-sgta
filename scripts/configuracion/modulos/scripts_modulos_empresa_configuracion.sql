-- PROCESO ALMACENADO PARA INSERTAR Y ACTUALIZAR LAS MODULOS DE LA EMPRESA
CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_modulo_empresa(i_json_data jsonb, i_empresa_id integer, i_usuario_accion integer) LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_modulos_empresa seguridad.tbl_modulos_empresas;
    v_estado_activo integer := 1;

    v_id_modulo integer := COALESCE((i_json_data->>'id_modulo'), '0')::integer;
    v_id_modulo_empresa integer := (SELECT id_modulo_empresa FROM seguridad.tbl_modulos_empresas WHERE (id_empresa = i_empresa_id AND id_modulo = v_id_modulo));
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_modulos WHERE id_modulo = v_id_modulo) THEN
        RAISE EXCEPTION '{"statusCode":400, "message": "No se ha encontrado uno de los módulos - %"}', v_id_modulo;
    END IF;

    IF v_id_modulo_empresa IS NULL THEN
        INSERT INTO seguridad.tbl_modulos_empresas
        (id_estado, usuario_crea, fecha_crea,  id_empresa, id_modulo)
        VALUES(v_estado_activo, i_usuario_accion, now(), i_empresa_id, v_id_modulo)
        RETURNING * INTO v_tbl_modulos_empresa;
    ELSE
        UPDATE seguridad.tbl_modulos_empresas
        SET id_estado=v_estado_activo, usuario_actua=i_usuario_accion, fecha_actua=now()
        WHERE id_modulo_empresa=v_id_modulo_empresa
        RETURNING * INTO v_tbl_modulos_empresa;
    END IF;

    IF v_tbl_modulos_empresa.id_modulo_empresa IS NULL THEN
        RAISE EXCEPTION '{"statusCode":500, "message": "No se ha podido insertar el módulo de la empresa"}';
    END IF;
END
$$;
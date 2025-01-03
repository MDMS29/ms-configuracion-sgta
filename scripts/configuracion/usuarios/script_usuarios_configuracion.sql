-- FUNCION ALMACENADA PARA OBTENER LOS USUARIOS
CREATE OR REPLACE FUNCTION seguridad.fnc_obtener_usuarios(i_params jsonb) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    data_return jsonb;
    v_estado_activo integer := 1;

    v_id_estado integer := COALESCE((i_params->>'estado')::integer, v_estado_activo);
    v_id_empresa integer := COALESCE((i_params->>'empresa')::integer, 0);

BEGIN
    v_data_return := (
        SELECT jsonb_agg(to_jsonb(q)) FROM (
            SELECT
                stu.id_usuario, CONCAT(stu.nombres, ' ', stu.apellidos) AS nombre, stu.usuario, stu.correo
            FROM seguridad.tbl_usuarios stu
            WHERE stu.id_estado = v_id_estado AND (v_id_empresa = 0 OR stu.id_empresa = v_id_empresa)
            ORDER BY id_usuario DESC
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
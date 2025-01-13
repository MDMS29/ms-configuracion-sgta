-- FUNCION ALMACENADA PARA BUSCAR EL USUARIO AUTENTICADO
CREATE OR REPLACE FUNCTION seguridad.fnc_buscar_usuario_autorizado(i_usuario integer) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_estado_activo integer := 1;
    v_data_return jsonb;
	
	v_ids_perfiles int[];
	v_perfiles jsonb;

	v_modulos jsonb;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_usuarios WHERE id_usuario = i_usuario AND id_estado = v_estado_activo) THEN
        RETURN jsonb_build_object(
            'statusCode', 404,
            'error', true,
            'message', 'No se ha encontrado el registro'
        );
    END IF;

	--CARGAR LOS PERFILES DEL USUARIO
	v_ids_perfiles := ARRAY(SELECT id_perfil FROM seguridad.tbl_perfiles_usuarios WHERE id_usuario = i_usuario AND id_estado = v_estado_activo);
	v_perfiles := (
					SELECT jsonb_agg(to_jsonb(q2)) FROM (
						SELECT 
							stpu.id_perfil_usuario, stpu.id_perfil, stpu.id_estado, stp.descripcion
						FROM seguridad.tbl_perfiles_usuarios stpu
						INNER JOIN seguridad.tbl_perfiles stp ON stp.id_perfil = stpu.id_perfil
	                    WHERE stpu.id_perfil = ANY(v_ids_perfiles) AND stp.id_estado = v_estado_activo
					) AS q2
				);

	v_modulos := (
		SELECT jsonb_agg(to_jsonb(q)) FROM (
            SELECT DISTINCT
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
            INNER JOIN seguridad.tbl_menus stm2 ON stm2.id_modulo = stm.id_modulo
            WHERE stm.id_estado = v_estado_activo
            AND (
            	stm.id_modulo = ANY(
            		ARRAY(
            			SELECT stam2.id_modulo
            			FROM seguridad.tbl_acciones_perfiles stap2
            			INNER JOIN seguridad.tbl_acciones_menus stam2 ON stam2.id_accion_menu = stap2.id_accion_menu
            			WHERE stap2.id_perfil = ANY(v_ids_perfiles)
            		)
            	)
            	OR
            	(
            		stm2.id_menu = ANY(
	            		ARRAY(
	            			SELECT stam2.id_menu
	            			FROM seguridad.tbl_acciones_perfiles stap2
	            			INNER JOIN seguridad.tbl_acciones_menus stam2 ON stam2.id_accion_menu = stap2.id_accion_menu
	            			WHERE stap2.id_perfil = ANY(v_ids_perfiles)
	            		)
	            	)
            	)
            )
        ) AS q
	);
	

    v_data_return := (
        SELECT to_jsonb(q) FROM (
            SELECT 
                stu.id_usuario, stu.usuario, stu.nombres, stu.apellidos, stu.correo, stu.cm_clave,
                v_perfiles AS perfiles,
				v_modulos AS modulos
            FROM seguridad.tbl_usuarios stu 
            WHERE (i_usuario = 0 OR stu.id_usuario = i_usuario)
            AND stu.id_estado = v_estado_activo
            --AND (v_usuario = '' OR stu.usuario = v_usuario)
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

SELECT * FROM seguridad.fnc_buscar_usuario_autorizado(6);





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
                            AND tam.id_estado = 1
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
                                    AND tam.id_estado = 1
                                ) AS q4) AS acciones
                            FROM seguridad.tbl_menus tm
                            WHERE tm.id_modulo = stm.id_modulo
                            AND tm.id_estado = 1
                        ) AS q3
                    )
                END AS menus
            FROM seguridad.tbl_modulos stm
            INNER JOIN seguridad.tbl_menus stm2 ON stm2.id_modulo = stm.id_modulo
            WHERE stm.id_estado = 1
            AND (
            	stm.id_modulo = ANY(
            		ARRAY(
            			SELECT stam2.id_modulo
            			FROM seguridad.tbl_acciones_perfiles stap2
            			INNER JOIN seguridad.tbl_acciones_menus stam2 ON stam2.id_accion_menu = stap2.id_accion_menu
            			WHERE stap2.id_perfil IN (1)
            		)
            	)
            	OR
            	(
            		stm2.id_menu = ANY(
	            		ARRAY(
	            			SELECT stam2.id_menu
	            			FROM seguridad.tbl_acciones_perfiles stap2
	            			INNER JOIN seguridad.tbl_acciones_menus stam2 ON stam2.id_accion_menu = stap2.id_accion_menu
	            			WHERE stap2.id_perfil IN (1)
	            		)
	            	)
            	)
            )
        ) AS q
import { PostgresDB } from "@config/postgres.config";

export class PerfilesQuerys {

    private postgres: PostgresDB = new PostgresDB();

    constructor() { }

    async obtener_perfiles(estado: string, empresa: string) {
        const res = await this.postgres.query(`
            SELECT stp.id_perfil, stp.descripcion, ste.razon_social AS empresa 
            FROM seguridad.tbl_perfiles stp
            INNER JOIN seguridad.tbl_empresas ste ON ste.id_empresa = stp.id_empresa
            WHERE stp.id_estado = $1 AND ($2 = 0 OR stp.id_empresa = $2)`, [estado, empresa])
        return res?.rows
    }

    async insertar_actualizar_perfil(perfil: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_insertar_actualizar_perfil('${perfil}', '{}')`)
        return res.rows[0].results
    }

    async buscar_perfil_id(params: string) {
        const res: any = await this.postgres.function('seguridad.fnc_buscar_perfil_id($1)', [params])
        return res?.rows[0].fnc_buscar_perfil_id
    }

    async inactivar_activar_perfil(parametros: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_inactivar_activar_perfil('${parametros}', '{}')`)
        return res?.rows[0].results
    }
}
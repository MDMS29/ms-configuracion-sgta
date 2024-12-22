import { PostgresDB } from "@config/postgres.config";

export class ModulosQuerys {

    private postgres: PostgresDB = new PostgresDB();

    constructor() { }

    async obtener_modulos(estado: string) {
        const res: any = await this.postgres.function('seguridad.fnc_obtener_modulos($1)', [estado])
        return res?.rows[0].fnc_obtener_modulos
    }

    async insertar_actualizar_modulo(modulo: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_insertar_actualizar_modulo('${modulo}', '{}')`)
        return res.rows[0].results
    }

    async buscar_modulo_id(id: string) {
        const res = await this.postgres.query('SELECT id_modulo, descripcion FROM seguridad.tbl_moduloes WHERE id_modulo = $1', [id])
        return res?.rows[0]
    }

    async inactivar_activar_modulo(parametros: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_inactivar_activar_modulo('${parametros}', '{}')`)
        return res?.rows[0].results
    }
}
import { PostgresDB } from "@config/postgres.config";

export class PerfilesQuerys {

    private postgres: PostgresDB = new PostgresDB();

    constructor() { }

    async obtener_perfiles(estado: string) {
        const res = await this.postgres.query('SELECT id_accion, descripcion FROM seguridad.tbl_acciones WHERE id_estado = $1', [estado])
        return res?.rows
    }

    async insertar_actualizar_accion(accion: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_insertar_actualizar_accion('${accion}', '{}')`)
        return res.rows[0].results
    }

    async buscar_accion_id(id: string) {
        const res = await this.postgres.query('SELECT id_accion, descripcion FROM seguridad.tbl_acciones WHERE id_accion = $1', [id])
        return res?.rows[0]
    }

    async inactivar_activar_accion(parametros: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_inactivar_activar_accion('${parametros}', '{}')`)
        return res?.rows[0].results
    }
}
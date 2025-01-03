import { PostgresDB } from "@config/postgres.config";

export class UsuariosQuerys {

    private postgres: PostgresDB = new PostgresDB();

    constructor() { }

    async obtener_usuarios(params: string) {
        const res: any = await this.postgres.function('seguridad.fnc_obtener_usuarios($1)', [params])
        return res?.rows[0].fnc_obtener_usuarios
    }

    async insertar_actualizar_accion(accion: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_insertar_actualizar_accion('${accion}', '{}')`)
        return res.rows[0].results
    }

    async buscar_accion_id(id: string) {
        const res = await this.postgres.query('SELECT id_accion, descripcion FROM seguridad.tbl_usuarios WHERE id_accion = $1', [id])
        return res?.rows[0]
    }

    async inactivar_activar_accion(parametros: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_inactivar_activar_accion('${parametros}', '{}')`)
        return res?.rows[0].results
    }
}
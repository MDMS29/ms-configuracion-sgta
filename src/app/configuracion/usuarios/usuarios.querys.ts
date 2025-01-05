import { PostgresDB } from "@config/postgres.config";

export class UsuariosQuerys {

    private postgres: PostgresDB = new PostgresDB();

    constructor() { }

    async obtener_usuarios(params: string) {
        const res: any = await this.postgres.function('seguridad.fnc_obtener_usuarios($1)', [params])
        return res?.rows[0].fnc_obtener_usuarios
    }

    async insertar_actualizar_usuario(usuario: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_insertar_actualizar_usuario('${usuario}', '{}')`)
        return res.rows[0].results
    }

    async buscar_usuario_id(params: string) {
        const res: any = await this.postgres.function('seguridad.fnc_buscar_usuario_id($1)', [params])
        return res?.rows[0].fnc_buscar_usuario_id
    }

    async inactivar_activar_usuario(parametros: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_inactivar_activar_usuario('${parametros}', '{}')`)
        return res?.rows[0].results
    }
}
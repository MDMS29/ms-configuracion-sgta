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

    async buscar_modulo_id(params: string) {
        const res: any = await this.postgres.function(`seguridad.fnc_buscar_modulo_id('${params}')`)
        return res?.rows[0].fnc_buscar_modulo_id
    }

    async inactivar_activar_modulo(parametros: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_inactivar_activar_modulo('${parametros}', '{}')`)
        return res?.rows[0].results
    }
}
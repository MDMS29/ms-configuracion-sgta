import { PostgresDB } from "@config/postgres.config";

export class EmpresasQuerys {

    private postgres: PostgresDB = new PostgresDB();

    constructor() { }

    async obtener_empresas(estado: string) {
        const res: any = await this.postgres.function('seguridad.fnc_obtener_empresas($1)', [estado])
        return res?.rows[0].fnc_obtener_empresas
    }

    async insertar_actualizar_empresa(empresa: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_insertar_actualizar_empresa('${empresa}', '{}')`)
        return res.rows[0].results
    }

    async buscar_empresa_id(id: string) {
        const res: any = await this.postgres.function('seguridad.fnc_buscar_empresa_id($1)', [id])
        return res?.rows[0].fnc_buscar_empresa_id
    }

    async inactivar_activar_empresa(parametros: string) {
        const res: any = await this.postgres.procedure(`seguridad.prc_inactivar_activar_empresa('${parametros}', '{}')`)
        return res?.rows[0].results
    }
}
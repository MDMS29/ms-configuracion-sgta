import { PostgresDB } from "@config/postgres.config";

export class AuthQuerys {

    private postgres: PostgresDB = new PostgresDB();

    constructor() { }

    async inicio_sesion(id: number) {
        const res: any = await this.postgres.function('seguridad.fnc_buscar_usuario_autorizado($1)', [id])
        return res?.rows[0].fnc_buscar_usuario_autorizado
    }
}
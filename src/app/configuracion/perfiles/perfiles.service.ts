import { BaseService } from "@common/bases/services.base";
import { PerfilesQuerys } from "./perfiles.querys";
import { DB_ESTADOS, REPONSES_CODES } from "@common/constants/constantes";

export class PerfilesService extends BaseService<PerfilesQuerys> {
    constructor() {
        super(PerfilesQuerys);
    }

    async obtener_perfiles(estado: string, empresa: string) {
        const perfiles = await this.query.obtener_perfiles(estado, empresa)

        return { statusCode: REPONSES_CODES.OK, message: 'OK', data: perfiles }
    }

    async insertar_actualizar_perfil(perfil: any) {
        perfil.usuario_accion = 1

        // PARSEAR DATA A STRING PARA PROCEDURE
        perfil = JSON.stringify(perfil)

        const response = await this.query.insertar_actualizar_perfil(perfil)

        return response
    }

    async buscar_perfil_id(id: string, estado: string) {

        const params = JSON.stringify({ id, estado: estado ?? DB_ESTADOS.ACTIVO })

        const response = await this.query.buscar_perfil_id(params)

        if (!response) {
            return { statusCode: REPONSES_CODES.NOT_FOUND, message: 'No se ha encontro el registro', data: {} }
        }

        return response
    }

    async inactivar_activar_perfil(id: string, estado: string) {
        const data = { id, estado, usuario_accion: 1 }
        const parametros = JSON.stringify(data)

        const response = await this.query.inactivar_activar_perfil(parametros)

        return response
    }

}
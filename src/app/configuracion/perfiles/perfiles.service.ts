import { BaseService } from "@common/bases/services.base";
import { PerfilesQuerys } from "./perfiles.querys";
import { REPONSES_CODES } from "@common/constants/constantes";

export class PerfilesService extends BaseService<PerfilesQuerys> {
    constructor() {
        super(PerfilesQuerys);
    }

    async obtener_perfiles(estado: string) {
        const perfiles = await this.query.obtener_perfiles(estado)

        return { statusCode: REPONSES_CODES.OK, message: 'OK', data: perfiles }
    }

    async insertar_actualizar_accion(accion: any) {
        accion.usuario_accion = 1

        // PARSEAR DATA A STRING PARA PROCEDURE
        accion = JSON.stringify(accion)

        const response = await this.query.insertar_actualizar_accion(accion)

        return response
    }

    async buscar_accion_id(id: string) {
        const accion = await this.query.buscar_accion_id(id)

        if (!accion) {
            return { statusCode: REPONSES_CODES.NOT_FOUND, message: 'No se ha encontro el registro', data: {} }
        }

        return { statusCode: REPONSES_CODES.OK, message: 'OK', data: accion }
    }

    async inactivar_activar_accion(id: string, estado: string) {
        const data = { id, estado, usuario_accion: 1 }
        const parametros = JSON.stringify(data)

        const response = await this.query.inactivar_activar_accion(parametros)

        return response
    }

}
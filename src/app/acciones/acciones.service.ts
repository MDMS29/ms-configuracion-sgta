import { BaseService } from "@common/bases/services.base";
import { AccionesQuerys } from "./acciones.querys";
import { REPONSES_CODES } from "@common/constants/constantes";

export class AccionesService extends BaseService<AccionesQuerys> {
    constructor() {
        super(AccionesQuerys);
    }

    async obtener_acciones() {
        const acciones = await this.query.obtener_acciones()

        return { statusCode: REPONSES_CODES.OK, message: 'OK', data: acciones }
    }

    async insertar_accion(accion: any) {
        accion.usuario_accion = 1

        const response = await this.query.insertar_actualizar_accion(accion)

        if (response.statusCode === REPONSES_CODES.OK) {
            response.statusCode = REPONSES_CODES.CREATED
        }

        return response
    }

    async buscar_accion_id(id: string) {
        const accion = await this.query.buscar_accion_id(id)

        if (!accion) {
            return { statusCode: REPONSES_CODES.NOT_FOUND, message: 'No se ha encontro el registro', data: {} }
        }

        return { statusCode: REPONSES_CODES.OK, message: 'OK', data: accion }
    }

}
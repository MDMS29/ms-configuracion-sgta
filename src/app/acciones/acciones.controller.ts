import { BaseController } from "@common/bases/controller.base";
import { AccionesService } from "./acciones.service";
import { serverResponse } from "src/helpers/server-response";
import { REPONSES_CODES } from "@common/constants/constantes";

export class AccionesController extends BaseController<AccionesService> {
    constructor() {
        super(AccionesService);
    }

    async obtener_acciones(_: any, res: any) {
        const acciones = await this.service.obtener_acciones()

        serverResponse(res, { statusCode: REPONSES_CODES.OK, message: 'OK', data: acciones })
    }

    async insertar_accion(req: any, res: any) {
        const accion = req.body

        const response = await this.service.insertar_accion(accion)

        serverResponse(res, response)
    }

    async buscar_accion_id(req: any, res: any) {
        const { id } = req.params

        const response = await this.service.buscar_accion_id(id)

        serverResponse(res, response)
    }

    async actualizar_accion(req: any, res: any) {
        const { id } = req.params
        const accion = req.body

        if(!id) serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la accion', data: {} })

        accion.id_accion = id

        const response = await this.service.insertar_accion(accion)

        serverResponse(res, response)
    }
}
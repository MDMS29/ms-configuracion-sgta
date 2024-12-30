import { BaseController } from "@common/bases/controller.base";
import { EmpresasService } from "./empresas.service";
import { serverResponse } from "src/helpers/server-response";
import { DB_ESTADOS, REPONSES_CODES } from "@common/constants/constantes";
import { EmpresaSchema } from "./empresas.dto";

export class EmpresasController extends BaseController<EmpresasService> {
    constructor() {
        super(EmpresasService);
    }

    async obtener_empresas(req: any, res: any) {
        const { estado } = req.query

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la operación', data: [] })

        const response = await this.service.obtener_empresas(estado)

        return serverResponse(res, response)
    }

    async insertar_empresa(req: any, res: any) {
        const empresa = req.body

        const validate = EmpresaSchema.safeParse(empresa)
        if (!validate.success) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: validate.error.issues[0].message })

        const response = await this.service.insertar_actualizar_empresa(empresa)

        return serverResponse(res, response)
    }

    async buscar_empresa_id(req: any, res: any) {
        const { id } = req.params
        const { estado } = req.query

        if (!id) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la empresa', data: {} })

        const params = JSON.stringify({ id: Number(id), estado: estado ?? DB_ESTADOS.ACTIVO })

        const response = await this.service.buscar_empresa_id(params)

        return serverResponse(res, response)
    }

    async actualizar_empresa(req: any, res: any) {
        const { id } = req.params
        const empresa = req.body

        if (!id || !Number(id)) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la operación', data: {} })

        empresa.id_empresa = Number(id)

        const validate = EmpresaSchema.safeParse(empresa)
        if (!validate.success) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: validate.error.issues[0].message })

        const response = await this.service.insertar_actualizar_empresa(empresa)

        return serverResponse(res, response)
    }

    async inactivar_activar_empresa(req: any, res: any) {
        const { id } = req.params
        const { estado } = req.query

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la empresa', data: {} })

        if (!id) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la empresa', data: {} })

        const response = await this.service.inactivar_activar_empresa(id, estado)

        return serverResponse(res, response)
    }
}
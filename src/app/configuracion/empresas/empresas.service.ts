import { BaseService } from "@common/bases/services.base";
import { EmpresasQuerys } from "./empresas.querys";
import { REPONSES_CODES } from "@common/constants/constantes";

export class EmpresasService extends BaseService<EmpresasQuerys> {
    constructor() {
        super(EmpresasQuerys);
    }

    async obtener_empresas(estado: string) {
        const response = await this.query.obtener_empresas(estado)

        return response
    }

    async insertar_actualizar_empresa(empresa: any) {
        empresa.usuario_accion = 1

        // PARSEAR DATA A STRING PARA PROCEDURE
        empresa = JSON.stringify(empresa)

        const response = await this.query.insertar_actualizar_empresa(empresa)

        return response
    }

    async buscar_empresa_id(params: string) {


        const response = await this.query.buscar_empresa_id(params)

        if (!response) {
            return { statusCode: REPONSES_CODES.NOT_FOUND, message: 'No se ha encontro el registro', data: {} }
        }

        return response
    }

    async inactivar_activar_empresa(id: string, estado: string) {
        const data = { id, estado, usuario_accion: 1 }
        const parametros = JSON.stringify(data)

        const response = await this.query.inactivar_activar_empresa(parametros)

        return response
    }

}
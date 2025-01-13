import { BaseController } from "@common/bases/controller.base";
import { AuthService } from "./auth.service";
import { serverResponse } from "src/helpers/server-response";
import { REPONSES_CODES } from "@common/constants/constantes";
import { InicioSesionSchema } from "./auth.dto";

export class AuthController extends BaseController<AuthService> {
    constructor() {
        super(AuthService);
    }

    async inicio_sesion(req: any, res: any) {
        
        const validate = InicioSesionSchema.safeParse(req.body)
        if (!validate.success) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: validate.error.issues[0].message })

        const response = await this.service.inicio_sesion(req.body)

        return serverResponse(res, response)
    }
}
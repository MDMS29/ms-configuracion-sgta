import { BaseRouter } from "@common/bases/router.base";
import { AuthController } from "./auth.controller";

export class AuthRouter extends BaseRouter<AuthController> {

    constructor() {
        super(AuthController, "auth");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .post((req, res) => this.controller.inicio_sesion(req, res))
    }

}

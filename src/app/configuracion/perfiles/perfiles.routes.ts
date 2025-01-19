import { BaseRouter } from "@common/bases/router.base";
import { PerfilesController } from "./perfiles.controller";
import { sessionMiddleware } from "src/middlewares/session.middleware";

export class PerfilesRouter extends BaseRouter<PerfilesController> {

    constructor() {
        super(PerfilesController, "configuracion/perfiles");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get(sessionMiddleware, (req, res) => this.controller.obtener_perfiles(req, res))
            .post(sessionMiddleware, (req, res) => this.controller.insertar_perfil(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get(sessionMiddleware, (req, res) => this.controller.buscar_perfil_id(req, res))
            .put(sessionMiddleware, (req, res) => this.controller.actualizar_perfil(req, res))
            .delete(sessionMiddleware, (req, res) => this.controller.inactivar_activar_perfil(req, res))
    }

}

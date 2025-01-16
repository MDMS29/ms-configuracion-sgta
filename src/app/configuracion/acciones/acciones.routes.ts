import { BaseRouter } from "@common/bases/router.base";
import { AccionesController } from "./acciones.controller";
import { sessionMiddleware } from "src/middlewares/session.middleware";

export class AccionesRouter extends BaseRouter<AccionesController> {

    constructor() {
        super(AccionesController, "configuracion/acciones");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get(sessionMiddleware, (req, res) => this.controller.obtener_acciones(req, res))
            .post(sessionMiddleware, (req, res) => this.controller.insertar_accion(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get(sessionMiddleware, (req, res) => this.controller.buscar_accion_id(req, res))
            .put(sessionMiddleware, (req, res) => this.controller.actualizar_accion(req, res))
            .delete(sessionMiddleware, (req, res) => this.controller.inactivar_activar_accion(req, res))
    }

}

import { BaseRouter } from "@common/bases/router.base";
import { ModulosController } from "./modulos.controller";
import { sessionMiddleware } from "src/middlewares/session.middleware";

export class ModulosRouter extends BaseRouter<ModulosController> {

    constructor() {
        super(ModulosController, "configuracion/modulos");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get(sessionMiddleware, (req, res) => this.controller.obtener_modulos(req, res))
            .post(sessionMiddleware, (req, res) => this.controller.insertar_modulo(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get(sessionMiddleware, (req, res) => this.controller.buscar_modulo_id(req, res))
            .put(sessionMiddleware, (req, res) => this.controller.actualizar_modulo(req, res))
            .delete(sessionMiddleware, (req, res) => this.controller.inactivar_activar_modulo(req, res))
    }

}

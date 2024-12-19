import { BaseRouter } from "@common/bases/router.base";
import { AccionesController } from "./acciones.controller";

export class AccionesRouter extends BaseRouter<AccionesController> {

    constructor() {
        super(AccionesController, "acciones");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get((req, res) => this.controller.obtener_acciones(req, res))
            .post((req, res) => this.controller.insertar_accion(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get((req, res) => this.controller.buscar_accion_id(req, res))
            .put((req, res) => this.controller.actualizar_accion(req, res))
    }

}

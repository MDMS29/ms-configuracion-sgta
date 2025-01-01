import { BaseRouter } from "@common/bases/router.base";
import { PerfilesController } from "./perfiles.controller";

export class PerfilesRouter extends BaseRouter<PerfilesController> {

    constructor() {
        super(PerfilesController, "configuracion/perfiles");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get((req, res) => this.controller.obtener_perfiles(req, res))
            .post((req, res) => this.controller.insertar_perfil(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get((req, res) => this.controller.buscar_perfil_id(req, res))
            .put((req, res) => this.controller.actualizar_perfil(req, res))
            .delete((req, res) => this.controller.inactivar_activar_perfil(req, res))
    }

}

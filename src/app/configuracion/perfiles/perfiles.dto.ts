import z from "zod";

export interface PerfilesDto {
    id_perfil: number;
    id_empresa: number;
    descripcion: string;
    acciones: AccionesPerfil[];
}

interface AccionesPerfil {
    id_accion_perfil: number;
    id_accion_menu: number; // id de la accion
    id_estado: number;
}

export const PerfilesSchema = z.object({
    id_perfil: z.number({
        required_error: "Debe ingresar un identificador del perfil",
        invalid_type_error: "El identificador del perfil debe ser un número",
    }).optional(),
    id_empresa: z.number({
        required_error: "Seleccione una empresa",
        invalid_type_error: "El identificador de la empresa debe ser un número",
    }),
    descripcion: z.string({
        required_error: "Debe ingresar una descripción valida",
        invalid_type_error: "La descripción debe ser texto",
    }),
    acciones: z.array(
        z.object({
            id_accion_menu: z.number({
                required_error: "Debe ingresar un identificador de la acción",
                invalid_type_error: "El identificador de la acción debe ser un número",
            }),
            id_estado: z.number({
                required_error: "Debe ingresar el estado de la acción",
                invalid_type_error: "El estado debe ser un número",
            }),
        })
    ).optional(),
})
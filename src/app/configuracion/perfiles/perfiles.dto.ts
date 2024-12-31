import z from "zod";

export interface PerfilesDto {
    id_perfil: number;
    id_empresa: number;
    descripcion: string;
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
})
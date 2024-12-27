import z from "zod";

export const AccionSchema = z.object({
    id_accion: z.number({
        required_error: "Debe ingresar un identificador de la acción",
        invalid_type_error: "El identificador de la acción debe ser un número",
    }).optional(),
    descripcion: z.string({
        required_error: "Debe ingresar una descripción valida",
        invalid_type_error: "La descripción debe ser texto",
    }),
})
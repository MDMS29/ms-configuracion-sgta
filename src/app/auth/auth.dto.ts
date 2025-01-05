import z from "zod";

export interface InicioSesionDto {
    usuario: string;
    clave: string;
}

export interface UsuarioAutorizadoDto {
    id_usuario: number;
    nombres: string;
    apellidos: string;
    usuario: string;
    correo: string;
    
}

export const InicioSesionSchema = z.object({
    usuario: z.string({
        required_error: "Debe ingresar un usuario valido",
        invalid_type_error: "El usuario debe ser texto",
    }),
    clave: z.string({
        required_error: "Debe ingresar una clave valido",
        invalid_type_error: "La clave debe ser texto",
    })
})
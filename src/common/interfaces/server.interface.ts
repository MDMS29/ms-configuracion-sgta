export interface IResponse {
    statusCode: number;
    message: string;
    data?: any;
}

export interface IRequest {
    usuario_accion: number;
}
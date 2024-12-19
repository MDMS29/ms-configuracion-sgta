import { REPONSES_CODES } from "@common/constants/constantes";

interface IResponse {
    statusCode: number
    message: string
    data?: any
}

const esErrorCode = (statusCode: number) => statusCode >= REPONSES_CODES.BAD_REQUEST && statusCode < REPONSES_CODES.INTERNAL_SERVER_ERROR;

export const serverResponse = (res: any, response: IResponse) => {
    let error: boolean = false;
    const { statusCode, message, data } = response;

    error = esErrorCode(statusCode)

    return res.status(statusCode).json({ error, statusCode, message, data });
};
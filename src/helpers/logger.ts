export const logger = (req: any, _: any, next: any) => {
    let body: any = JSON.stringify(req.body) ?? ""

    console.log(`[${req.method}] ${req.originalUrl} - ${new Date().toISOString()} \n ${body}`);

    next()
};
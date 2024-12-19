export const logger = (req: any, _: any, next: any) => {
    console.log(`[${req.method}] ${req.originalUrl} - ${new Date().toISOString()} \n ${req.body}`)

    next()
};
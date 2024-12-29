const REQUEST_METHODS = {
    GET: "GET",
    POST: "POST",
    PUT: "PUT",
    DELETE: "DELETE"
}

export const logger = (req: any, _: any, next: any) => {
    const verBody = req.method === REQUEST_METHODS.POST || req.method === REQUEST_METHODS.PUT
    
    let body: any = JSON.stringify(req.body) ?? ""

    console.log(`[${req.method}] ${req.originalUrl} - ${new Date().toISOString()} \n ${verBody ? `${body} \n` : ""}`);

    next()
};
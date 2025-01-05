export const isEmpty = (param: any): boolean => {

    switch (typeof param) {
        case 'string':
            return param.trim().length === 0
        case 'number':
            return param === 0
        case 'object':
            return Object.keys(param).length === 0
        case 'boolean':
            return param === false
    }

    return false

}
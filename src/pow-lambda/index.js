/**
 * 
 * AWS Lambda POW handler
 * @param {AWS Event} event 
 * @param {AWS Context} context 
 */
exports.handler = async (event) => {
    return Math.pow(event.base, event.exponent);
};
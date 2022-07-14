/**
 * 
 * AWS Lambda Rand handler
 * @param {AWS Event} event 
 * @param {AWS Context} context 
 */
exports.handler = async (event) => {
    const MIN = (event.min === undefined) ? 1 : event.min;
    const MAX = (event.max === undefined) ? 10 : event.max;
    return Math.floor((Math.random() * MAX) + MIN);
};
function addNumbers(...args) {
    
    if (args.length < 2) {
        throw new Error("At least two numbers are required.");
    }

    return args.reduce((sum, num) => sum + num, 0);
}

module.exports = addNumbers;
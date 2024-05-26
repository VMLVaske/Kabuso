const snarkjs = require('snarkjs')
const crypto = require('crypto')
const circomlib = require('circomlib')
const bigInt = snarkjs.bigInt
const fs = require('fs')

/** Generate random number of specified byte length */
const rbigint = nbytes => snarkjs.bigInt.leBuff2int(crypto.randomBytes(nbytes))

/** Compute pedersen hash */
const pedersenHash = data => circomlib.babyJub.unpackPoint(circomlib.pedersenHash.hash(data))[0]

/** BigNumber to hex string of specified length */
function toHex(number, length = 32) {
    const str = number instanceof Buffer ? number.toString('hex') : bigInt(number).toString(16)
    return '0x' + str.padStart(length * 2, '0')
}

/**
 * Create deposit object from secret and nullifier
 */
function createDeposit({ nullifier, secret }) {
    const deposit = { nullifier, secret }
    deposit.preimage = Buffer.concat([deposit.nullifier.leInt2Buff(31), deposit.secret.leInt2Buff(31)])
    deposit.commitment = pedersenHash(deposit.preimage)
    deposit.commitmentHex = toHex(deposit.commitment)
    deposit.nullifierHash = pedersenHash(deposit.nullifier.leInt2Buff(31))
    deposit.nullifierHex = toHex(deposit.nullifierHash)
    return deposit
}


/**
 * Make a deposit
 * @param currency Сurrency
 * @param amount Deposit amount
 */
async function deposit() {
    const deposit = createDeposit({ nullifier: rbigint(31), secret: rbigint(31) })
    const note = toHex(deposit.preimage, 62)
    const data = `function getNote(${note}) {console.log(${note});}getNote();`

    /* console.log('Deposit:', deposit)
    console.log("Deposit in Hex: ", toHex(deposit.commitment)) */

    try {
        fs.writeFileSync('./helpers/note.js', data)
        fs.writeFileSync('./helpers/noteString.txt', note)
        fs.writeFileSync('./helpers/deposit.json', JSON.stringify(deposit))
    } catch (err) { }

    console.log(toHex(deposit.commitment));
    //console.log(noteString);
    //await tornado.methods.deposit(toHex(deposit.commitment)).send({ value, from: senderAccount, gas: 2e6 })

}

deposit();
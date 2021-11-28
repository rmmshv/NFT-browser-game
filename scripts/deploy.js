const main = async() => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    // Compiles the contract and generate artifacts
    const gameContract = await gameContractFactory.deploy(
        ["Re-l", "Pino", "Vincent"], ["https://i.imgur.com/XS6u8do.mp4",
            "https://c.tenor.com/EBeS0PbCCXAAAAAM/pino-ergo-proxy.gif",
            "https://giffiles.alphacoders.com/100/100313.gif"
        ], [150, 300, 200], [150, 300, 100],
        "Prison Mike", // Big badass boss
        "https://cdn.costumewall.com/wp-content/uploads/2018/09/prison-mike.jpg",
        1000000, // Boss hp
        69 // attack damage
    );
    await gameContract.deployed();
    console.log("Contract deployed to: ", gameContract.address);

    // console.log("Done!");
};

const runMain = async() => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();
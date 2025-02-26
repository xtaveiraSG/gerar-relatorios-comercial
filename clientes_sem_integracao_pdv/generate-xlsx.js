const fs = require("fs");
const path = require("path");
const xlsx = require("xlsx");

// Função para encontrar os arquivos JSON mais recentes (SG e RJK)
function findLatestFiles(directory) {
    const files = fs.readdirSync(directory)
        .filter(file => file.endsWith(".json"))
        .sort((a, b) => b.localeCompare(a)); // Ordena pela data mais recente

    const latestSG = files.find(file => file.includes("-sg"));
    const latestRJK = files.find(file => file.includes("-rjk"));

    if (!latestSG || !latestRJK) {
        throw new Error("Arquivos SG e RJK mais recentes não encontrados.");
    }

    return {
        sg: path.join(directory, latestSG),
        rjk: path.join(directory, latestRJK),
        date: latestSG.split("-")[0] // Usa a data do arquivo SG como referência
    };
}

// Função para carregar e extrair os dados JSON corretamente
function loadJson(filePath) {
    const data = JSON.parse(fs.readFileSync(filePath, "utf-8"));
    const key = Object.keys(data).find(key => Array.isArray(data[key])); // Detecta a chave que contém um array

    return key ? data[key] : []; // Retorna o array de objetos ou vazio
}

// Ajusta automaticamente a largura das colunas
function autoAdjustColumns(worksheet, jsonData) {
    const colWidths = Object.keys(jsonData[0] || {}).map(key => {
        return Math.max(key.length, ...jsonData.map(row => String(row[key] || "").length));
    });

    worksheet["!cols"] = colWidths.map(width => ({ wch: width + 2 })); // Ajuste extra
}

// Função principal para criar a planilha XLSX
function createExcelFile(outputPath, sgData, rjkData) {
    const uniqueData = new Map();

    // Adiciona primeiro os registros da SG (prioridade)
    sgData.forEach(item => uniqueData.set(item.CNPJ, item));

    // Adiciona registros da RJK apenas se o CNPJ não estiver na SG
    rjkData.forEach(item => {
        if (!uniqueData.has(item.CNPJ)) {
            uniqueData.set(item.CNPJ, item);
        }
    });

    const finalData = Array.from(uniqueData.values());

    if (finalData.length === 0) {
        throw new Error("Nenhum dado disponível para gerar a planilha.");
    }

    const worksheet = xlsx.utils.json_to_sheet(finalData);
    autoAdjustColumns(worksheet, finalData);

    const workbook = xlsx.utils.book_new();
    xlsx.utils.book_append_sheet(workbook, worksheet, "Clientes");

    xlsx.writeFile(workbook, outputPath);
}

// Executa o script
(function () {
    try {
        const directory = __dirname;
        const { sg, rjk, date } = findLatestFiles(directory);

        console.log(`📂 Processando arquivos:\nSG: ${sg}\nRJK: ${rjk}`);

        const sgData = loadJson(sg);
        const rjkData = loadJson(rjk);

        if (sgData.length === 0 && rjkData.length === 0) {
            throw new Error("Nenhum dado encontrado nos arquivos JSON.");
        }

        const outputFileName = `${date}-clientes-sem-integracao-pdv.xlsx`;
        const outputPath = path.join(directory, outputFileName);

        createExcelFile(outputPath, sgData, rjkData);

        console.log(`✅ Planilha gerada com sucesso: ${outputFileName}`);
    } catch (error) {
        console.error(`❌ Erro: ${error.message}`);
    }
})();

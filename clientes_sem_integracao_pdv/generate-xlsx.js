const fs = require("fs");
const path = require("path");
const xlsx = require("xlsx");

// Diretório atual
const directory = __dirname;

// Função para pegar os arquivos mais recentes
function getLatestFiles() {
    const files = fs.readdirSync(directory);
    const sgFile = files.filter(f => f.match(/^\d{4}-\d{2}-\d{2}-SG\.json$/)).sort().reverse()[0];
    const rjkFile = files.filter(f => f.match(/^\d{4}-\d{2}-\d{2}-RJK\.json$/)).sort().reverse()[0];

    if (!sgFile || !rjkFile) {
        console.error("Arquivos SG ou RJK não encontrados!");
        return null;
    }

    return {
        sgFile: path.join(directory, sgFile),
        rjkFile: path.join(directory, rjkFile),
        date: sgFile.split("-SG.json")[0] // Pega a data do nome do arquivo
    };
}

// Função para ler e processar os arquivos JSON
function readJson(filename) {
    try {
        if (!fs.existsSync(filename)) {
            console.error(`Arquivo não encontrado: ${filename}`);
            return [];
        }

        const data = JSON.parse(fs.readFileSync(filename, "utf-8"));
        const key = Object.keys(data)[0]; // Pegando o nome do array
        return data[key] || [];
    } catch (error) {
        console.error(`Erro ao ler o arquivo ${filename}:`, error.message);
        return [];
    }
}

// Função para formatar datas (YYYY-MM-DD → DD/MM/YYYY)
function formatDate(date) {
    if (!date || !date.match(/^\d{4}-\d{2}-\d{2}$/)) return date;
    const [year, month, day] = date.split("-");
    return `${day}/${month}/${year}`;
}

// Criar a planilha XLSX
function createExcel(data, date) {
    if (data.length === 0) {
        console.error("Nenhum dado disponível para criar a planilha!");
        return;
    }

    const ws = xlsx.utils.json_to_sheet(data);

    // Ajustar o tamanho das colunas com base no maior valor
    const colWidths = Object.keys(data[0]).map(key => ({
        wch: Math.max(
            key.length, 
            ...data.map(row => (row[key] ? row[key].toString().length : 0))
        )
    }));
    ws["!cols"] = colWidths;

    // Criar o workbook e salvar
    const wb = xlsx.utils.book_new();
    xlsx.utils.book_append_sheet(wb, ws, "Clientes");

    const filename = path.join(directory, `${date}-clientes-sem-integracao-pdv.xlsx`);
    xlsx.writeFile(wb, filename);

    console.log(`✅ Planilha criada: ${filename}`);
}

// Função principal
function main() {
    const files = getLatestFiles();
    if (!files) return;

    const sgData = readJson(files.sgFile);
    const rjkData = readJson(files.rjkFile);

    // Remover duplicados (CNPJ) e garantir prioridade para SG
    const cnpjSet = new Set(sgData.map(item => item.CNPJ));
    const mergedData = [...sgData, ...rjkData.filter(item => !cnpjSet.has(item.CNPJ))];

    // Converter formato de data
    mergedData.forEach(item => {
        if (item["DATA_INSTALAÇÃO"]) {
            item["DATA_INSTALAÇÃO"] = formatDate(item["DATA_INSTALAÇÃO"]);
        }
    });

    createExcel(mergedData, files.date);
}

main();

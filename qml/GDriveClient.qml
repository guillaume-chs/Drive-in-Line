import QtQuick 2.4
import io.thp.pyotherside 1.4

Item {
    property var client
    property bool isConnected: false
    property var file_type: {
        'folder': 'application/vnd.google-apps.folder'
    }

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('gdrive.pydrive'));
            addImportPath(Qt.resolvedUrl('gdrive'));
            addImportPath(Qt.resolvedUrl('.'));

            importModule('gdrive.gdrive_client', function() {
                console.log('Google Drive module is now imported');

                gdrive.setClient('gdrive.gdrive_client.gdrive');
            });
        }
    }

    function setClient(new_client) {
        gdrive.client = new_client;
        gdrive.authenticate();
    }

    function authenticate(callback) {
        console.log('py.call : ' + gdrive.client + '.connect');
        py.call(gdrive.client + '.connect', [], function(result) {
            isConnected = true;
            gDriveInitialized();
            if (callback !== undefined) {
                callback(result);
            }
        });
    }

    function getDirFiles(directory, callback) {
        console.log('py.call : ' + gdrive.client + '.list_dir_files');
        py.call(gdrive.client + '.list_dir_files', [directory], callback);
    }

    function renameFile(fileId, fileName, callback) {
        console.log('py.call : ' + gdrive.client + '.rename_file');
        py.call(gdrive.client + '.rename_file', [fileId, fileName], callback);
    }

    function downloadFile(fileId, filePath, callback) {
        console.log('py.call : ' + gdrive.client + '.download_file');
        py.call(gdrive.client + '.download_file', [fileId, filePath], callback);
    }

    function openFile(fileId, callback) {
        console.log('py.call : ' + gdrive.client + '.open_file');
        py.call(gdrive.client + '.open_file', [fileId], callback);
    }

    function isFolder(file) {
        return file['mimeType'] === file_type['folder'];
    }
}

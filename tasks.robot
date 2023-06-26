*** Settings ***
Documentation       Ordena Robots de RobotSpareBin Industries Inc.
...                 Guarda el recibo de la orden html como archivo pdf.
...                 Guada captura del Robot ordenado.
...                 Integra la captura del Robot dentro del recibo PDF.
...                 Crea un archivo ZIP de las facturas y las imágenes.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Desktop
Library             OperatingSystem
Library             RPA.Archive


*** Tasks ***
Ordenar robots de RobotSpareBin Industries Inc
    Abrir el website para ordenar los robots
    Descargar el libro de ordenes
    Comprimir Recibos en un ZIP
    [Teardown]    Obtener ordenes e ingresarlas en la pagina web


*** Keywords ***
Abrir el website para ordenar los robots
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Descargar el libro de ordenes
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}

Obtener ordenes e ingresarlas en la pagina web
    ${Robot_Orders}=    Read table from csv    orders.csv    header=${True}
    FOR    ${Orden}    IN    @{Robot_Orders}
        Ingresar Orden en la Pagina web    ${Orden}
        Guardar Captura de la orden y de la imagen del bot    ${Orden}
        Agregar pantallazo en la factura de la orden    ${Orden}
        Click Button When Visible    order-another
        Remove File    Orders${/}${Orden}[Order number].png
    END

Ingresar Orden en la Pagina web
    [Arguments]    ${Orden}
    Click Button When Visible    css:Button.btn.btn-dark
    Select From List By Value    head    ${Orden}[Head]
    Select Radio Button    body    id-body-${Orden}[Body]
    Input Text    class:form-control    ${Orden}[Legs]
    Input Text    id:address    ${Orden}[Address]
    Click Button    preview
    Click Button    order

Guardar Captura de la orden y de la imagen del bot
    [Arguments]    ${Orden}
    Wait Until Element Is Visible    id:receipt
    ${Facura}=    Get Element Attribute    id:receipt    outerHTML
    ${Factura_PDF}=    Html To Pdf    ${Facura}    Orders${/}${Orden}[Order number].Pdf
    ${bot_Screenshot}=    Screenshot    robot-preview-image    Orders${/}${Orden}[Order number].png

Agregar pantallazo en la factura de la orden
    [Arguments]    ${Orden}
    ${Robot}=    Create List
    ...    Orders${/}${Orden}[Order number].png
    Add Files To Pdf    ${Robot}    Orders${/}${Orden}[Order number].Pdf    append=Bool:${True}

Comprimir Recibos en un ZIP
    Archive Folder With Zip    Orders    ${OUTPUT_DIR}${/}Ordenes.ZIP

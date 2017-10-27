SELECT y.projectname,
       x.service_id,
       x.portal_objname,
       x.menuname,
       x.component,
       x.page,
       x.record,
       x.field,
       x.event_type,
       x.seqnum AS seq_number,
       x.peoplecode_event
FROM   (
       /* Component Base Query */
       SELECT a.ptcs_serviceid AS service_id,
              a.portal_objname,
              b.menuname,
              b.pnlgrpname     AS component,
              a.pnlname        AS page,
              a.recname        AS RECORD,
              a.fieldname      AS field,
              'Component'      AS event_type,
              CASE a.ptcs_cmpevent
                WHEN 'POST' THEN 'PostBuild'
                WHEN 'PRE' THEN 'PreBuild'
                WHEN 'SPOS' THEN 'SavePostChange'
                WHEN 'SPRE' THEN 'SavePreChange'
                WHEN 'WFLO' THEN 'Workflow'
                ELSE ''
              END              AS peoplecode_event,
              a.ptcs_enable,
              a.seqnum
       FROM   psptcssrvconf a,
              psptcs_srvcfg b
       WHERE  a.portal_name = '_PTCS_PTEVMAP'
              AND a.ptcs_cmpevent <> ' '
              AND a.ptcs_iscompservice = 'C'
              AND a.portal_name = b.portal_name
              AND a.portal_objname = b.portal_objname
       UNION
       /* Page Base Query */
       SELECT a.ptcs_serviceid AS service_id,
              a.portal_objname,
              b.menuname,
              b.pnlgrpname     AS component,
              a.pnlname        AS page,
              a.recname        AS RECORD,
              a.fieldname      AS field,
              'Page'           AS event_type,
              'Activate'       AS peoplecode_event,
              a.ptcs_enable,
              a.seqnum
       FROM   psptcssrvconf a,
              psptcs_srvcfg b
       WHERE  a.portal_name = '_PTCS_PTEVMAP'
              AND a.pnlname <> ' '
              AND a.ptcs_cmprecevent = 'PACT'
              AND a.portal_name = b.portal_name
              AND a.portal_objname = b.portal_objname
       UNION
       /* Record Base Query */
       SELECT a.ptcs_serviceid   AS service_id,
              a.portal_objname,
              b.menuname,
              b.pnlgrpname       AS component,
              a.pnlname          AS page,
              a.recname          AS RECORD,
              a.fieldname        AS field,
              'Component Record' AS event_type,
              CASE a.ptcs_cmprecevent
                WHEN 'RDEL' THEN 'RowDelete'
                WHEN 'RINI' THEN 'RowInit'
                WHEN 'RINS' THEN 'RowInsert'
                WHEN 'RSEL' THEN 'RowSelect'
                WHEN 'SEDT' THEN 'SaveEdit'
                WHEN 'SPOS' THEN 'SavePostChange'
                WHEN 'SPRE' THEN 'SavePreChange'
                ELSE ''
              END                AS peoplecode_event,
              a.ptcs_enable,
              a.seqnum
       FROM   psptcssrvconf a,
              psptcs_srvcfg b
       WHERE  a.portal_name = '_PTCS_PTEVMAP'
              AND a.ptcs_cmprecevent <> ' '
              AND a.ptcs_iscompservice = 'P'
              AND a.portal_name = b.portal_name
              AND a.portal_objname = b.portal_objname
        UNION
        /* Record Field Base Query */
        SELECT a.ptcs_serviceid         AS service_id,
               a.portal_objname,
               b.menuname,
               b.pnlgrpname             AS component,
               a.pnlname                AS page,
               a.recname                AS RECORD,
               a.fieldname              AS field,
               'Component Record Field' AS event_type,
               CASE a.ptcs_cmprecevent
                 WHEN 'RFCH' THEN 'FieldChange'
                 ELSE ''
               END                      AS peoplecode_event,
              a.ptcs_enable,
              a.seqnum
        FROM   psptcssrvconf a,
               psptcs_srvcfg b
        WHERE  a.portal_name = '_PTCS_PTEVMAP'
               AND a.ptcs_cmprecevent <> ' '
               AND a.fieldname <> ' '
               AND a.portal_name = b.portal_name
               AND a.portal_objname = b.portal_objname) x,
       psprojectitem y
WHERE  y.projectname IN ( 'SV_EMF_TEST' ) /* <<<<<<<<<<<<< Insert your project list here */
       AND ( ( x.component = y.objectvalue1
               AND x.peoplecode_event = y.objectvalue3
               AND y.objecttype = 46 and x.ptcs_enable = 'Y')
              OR ( x.page = y.objectvalue1
                   AND x.peoplecode_event = y.objectvalue2
                   AND y.objecttype = 44 and x.ptcs_enable = 'Y')
              OR ( x.component = y.objectvalue1
                   AND x.RECORD = y.objectvalue3
                   AND x.peoplecode_event = y.objectvalue4
                   AND y.objecttype = 47 and x.ptcs_enable = 'Y')
              OR ( x.component = y.objectvalue1
                   AND x.RECORD = y.objectvalue3
                   AND x.field
                       || x.peoplecode_event = Replace(Y.objectvalue4, ' ', '')
                   AND y.objecttype = 48 and x.ptcs_enable = 'Y') )

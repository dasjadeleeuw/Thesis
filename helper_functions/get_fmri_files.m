function [path, fmri_files] = get_fmri_files(pp_nr)
% Returns paths to raw fMRI files

if pp_nr == 1
    path = "O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Femke Ruijs\fMRI data participant 01\S01WMWM\";
    fmri_files =  [ "Session1\mrVistaSession\clp_lo_EPI_01.nii"    %run 1
                        "Session1\mrVistaSession\clp_lo_EPI_02.nii"    %run 2
                        "Session1\mrVistaSession\clp_lo_EPI_03.nii"    %run 3
                        "Session2b\mrVistaSession\clp_lo_EPI_04.nii"    %run 4
                        "Session2b\mrVistaSession\clp_lo_EPI_06.nii"    %run 5
                        "Session2b\mrVistaSession\clp_lo_EPI_07.nii"    %run 6
                        "Session2b\mrVistaSession\clp_lo_EPI_08.nii"    %run 7
                        "Session2b\mrVistaSession\clp_lo_EPI_10.nii"    %run 8
                        "Session2b\mrVistaSession\clp_lo_EPI_11.nii"    %run 9
                        "Session2b\mrVistaSession\clp_lo_EPI_12.nii"    %run 10
                        "Session2b\mrVistaSession\clp_lo_EPI_13.nii"    %run 11
                        "Session2b\mrVistaSession\clp_lo_EPI_14.nii"    %run 12
                        "Session2b\mrVistaSession\clp_lo_EPI_15.nii"    %run 13
                        "Session3\mrVistaSession\clp_lo_EPI_04.nii"    %run 14
                        "Session3\mrVistaSession\clp_lo_EPI_06.nii"    %run 15
                        "Session3\mrVistaSession\clp_lo_EPI_07.nii"    %run 16
                        "Session3\mrVistaSession\clp_lo_EPI_08.nii"    %run 17
                        "Session3\mrVistaSession\clp_lo_EPI_09.nii"    %run 18
                        "Session3\mrVistaSession\clp_lo_EPI_12.nii"    %run 19
                        "Session3\mrVistaSession\clp_lo_EPI_13.nii"    %run 20
                        "Session3\mrVistaSession\clp_lo_EPI_14.nii"    %run 21
                        "Session3\mrVistaSession\clp_lo_EPI_15.nii"    %run 22
                        "Session3b\mrVistaSession\clp_lo_EPI_11.nii"    %run 23
                        "Session4\mrVistaSession\clp_lo_EPI_04.nii"    %run 24
                        "Session4\mrVistaSession\clp_lo_EPI_06.nii"    %run 25
                        "Session4\mrVistaSession\clp_lo_EPI_07.nii"    %run 26
                        "Session4\mrVistaSession\clp_lo_EPI_08.nii"    %run 27
                                                                        ];
elseif pp_nr == 2
    path = "O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Femke Ruijs\fMRI data participant 02\S02\";
    fmri_files =  [ "Session1a\mrVistaSession\clp_lo_EPI_01.nii"    %run 1
                        "Session1b\mrVistaSession\clp_lo_EPI_01.nii"    %run 2
                        "Session1b\mrVistaSession\clp_lo_EPI_02.nii"    %run 3
                        "Session1b\mrVistaSession\clp_lo_EPI_03.nii"    %run 4
                        "Session1b\mrVistaSession\clp_lo_EPI_04.nii"    %run 5
                        "Session1b\mrVistaSession\clp_lo_EPI_05.nii"    %run 6
                        "Session1b\mrVistaSession\clp_lo_EPI_06.nii"    %run 7
                        "Session1b\mrVistaSession\clp_lo_EPI_07.nii"    %run 8
                        "Session1b\mrVistaSession\clp_lo_EPI_08.nii"    %run 9
                        "Session1b\mrVistaSession\clp_lo_EPI_09.nii"    %run 10
                        "Session2\mrVistaSession\clp_lo_EPI_01.nii"    %run 11
                        "Session2\mrVistaSession\clp_lo_EPI_02.nii"    %run 12
                        "Session2\mrVistaSession\clp_lo_EPI_03.nii"    %run 13
                        "Session2\mrVistaSession\clp_lo_EPI_04.nii"    %run 14
                        "Session2\mrVistaSession\clp_lo_EPI_05.nii"    %run 15
                        "Session2\mrVistaSession\clp_lo_EPI_06.nii"    %run 16
                        "Session2\mrVistaSession\clp_lo_EPI_07.nii"    %run 17
                        "Session3\mrVistaSession\clp_lo_EPI_07.nii"    %run 18
                        "Session2\mrVistaSession\clp_lo_EPI_09.nii"    %run 19
                        "Session2\mrVistaSession\clp_lo_EPI_10.nii"    %run 20
                        "Session2\mrVistaSession\clp_lo_EPI_11.nii"    %run 21
                        "Session3\mrVistaSession\clp_lo_EPI_01.nii"    %run 22
                        "Session3\mrVistaSession\clp_lo_EPI_02.nii"    %run 23
                        "Session3\mrVistaSession\clp_lo_EPI_03.nii"    %run 24
                        "Session3\mrVistaSession\clp_lo_EPI_04.nii"    %run 25
                        "Session3\mrVistaSession\clp_lo_EPI_05.nii"    %run 26
                        "Session3\mrVistaSession\clp_lo_EPI_06.nii"    %run 27
                                                                        ];
elseif pp_nr == 3
    path = "O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Femke Ruijs\fMRI data participant 03\";
    fmri_files =  [ "s23\WMWM_Session1\mrVistaSession\clp_lo_EPI_04.nii"    %run 1
                        "s23\WMWM_Session1\mrVistaSession\clp_lo_EPI_06.nii"    %run 2
                        "s23\WMWM_Session1\mrVistaSession\clp_lo_EPI_07.nii"    %run 3
                        "s23\WMWM_Session1\mrVistaSession\clp_lo_EPI_09.nii"    %run 4
                        "s23\WMWM_Session1\mrVistaSession\clp_lo_EPI_10.nii"    %run 5
                        "s23\WMWM_Session1\mrVistaSession\clp_lo_EPI_11.nii"    %run 6
                        "s23\WMWM_Session1\mrVistaSession\clp_lo_EPI_12.nii"    %run 7
                        "s23\WMWM_Session1\mrVistaSession\clp_lo_EPI_14.nii"    %run 8
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_04.nii"    %run 9
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_06.nii"    %run 10
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_07.nii"    %run 11
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_08.nii"    %run 12
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_10.nii"    %run 13
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_11.nii"    %run 14
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_12.nii"    %run 15
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_13.nii"    %run 16
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_14.nii"    %run 17
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_15.nii"    %run 18
                        "s23\WMWM_Session2\mrVistaSession\clp_lo_EPI_17.nii"    %run 19
                        "s23\WMWM_Session3\mrVistaSession\clp_lo_EPI_04.nii"    %run 20
                        "s23\WMWM_Session3\mrVistaSession\clp_lo_EPI_06.nii"    %run 21
                        "s23\WMWM_Session3\mrVistaSession\clp_lo_EPI_07.nii"    %run 22
                        "s23\WMWM_Session3\mrVistaSession\clp_lo_EPI_08.nii"    %run 23
                        "s23\WMWM_Session3\mrVistaSession\clp_lo_EPI_10.nii"    %run 24
                        "s23\WMWM_Session3\mrVistaSession\clp_lo_EPI_11.nii"    %run 25
                        "s23\WMWM_Session3\mrVistaSession\clp_lo_EPI_12.nii"    %run 26
                        "s23\WMWM_Session3\mrVistaSession\clp_lo_EPI_13.nii"    %run 27
                                                                        ];
end


end